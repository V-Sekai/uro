import { unique } from "@ariesclark/extensions";
import { Slot } from "@radix-ui/react-slot";
import {
	useMutation,
	type UseMutationOptions,
	type UseMutationResult
} from "@tanstack/react-query";
import {
	createContext,
	use,
	useState,
	type Dispatch,
	type FC,
	type ReactNode
} from "react";

import { ErrorMessage } from "~/app/(static)/login/error-message";
import { Button, type ButtonProps } from "~/components/button";

export type MutationFormProps<TVariables, TData = unknown, TError = Error> = {
	className?: string;
	defaultVariables: TVariables;
	asChild?: boolean;
	children: (
		context: MutationFormContext<TVariables, TData, TError>
	) => ReactNode;
} & UseMutationOptions<TData, TError, TVariables>;

export type MutationFormContext<TVariables, TData = unknown, TError = Error> = {
	fields: {
		[K in keyof TVariables]: {
			name: K;
			value: TVariables[K];
			onChange: Dispatch<TVariables[K]>;
			errors: Array<string>;
		};
	};
} & Omit<UseMutationResult<TData, TError, TVariables>, "variables">;

export const MutationFormContext = createContext(
	{} as MutationFormContext<unknown>
);

export function MutationForm<TVariables, TData = unknown, TError = Error>({
	className,
	children,
	defaultVariables,
	asChild = false,
	...mutationOptions
}: MutationFormProps<TVariables, TData, TError>) {
	const mutation = useMutation(mutationOptions);

	/**
	 * Manually persist the current error, instead of using `error` from `useMutation`.
	 * This is because during a pending mutation, `error` is `null` and we want to display
	 * the last error until the new one is received.
	 */
	const [error, setError] = useState<unknown>(null);

	const errorProperties =
		error &&
		typeof error === "object" &&
		"properties" in error &&
		error.properties &&
		typeof error.properties === "object"
			? error.properties
			: {};

	const [variables, setVariables] = useState(defaultVariables);
	const [touchedRecently, setTouchedRecently] = useState(
		[] as Array<keyof TVariables>
	);

	const context = {
		...mutation,
		fields: Object.fromEntries(
			Object.entries(variables as ArrayLike<unknown>).map(([key, value]) => {
				type Value = TVariables[keyof TVariables];

				const setValue: Dispatch<Value> = (newValue) => {
					if (value === newValue) return;

					setTouchedRecently((touched) =>
						unique([...touched, key as keyof TVariables])
					);

					setVariables((variables) => ({
						...variables,
						[key]: newValue
					}));
				};

				const touched = touchedRecently.includes(key as keyof TVariables);

				return [
					key,
					{
						name: key,
						value,
						onChange: setValue,
						errors: touched
							? []
							: errorProperties[key as keyof typeof errorProperties] || []
					}
				];
			})
		)
	} as unknown as MutationFormContext<TVariables, TData, TError>;

	const Component = asChild ? Slot : "form";

	return (
		<MutationFormContext.Provider
			value={context as MutationFormContext<unknown, unknown, Error>}
		>
			<Component
				className={className}
				action={() =>
					mutation.mutate(variables, {
						onSettled: (data, error) => {
							if (error) setError(error);
							else setError(null);

							setTouchedRecently([]);
						}
					})
				}
			>
				{children(context)}
			</Component>
		</MutationFormContext.Provider>
	);
}

export const FormErrorMessage: FC = () => {
	const { error } = use(MutationFormContext);

	return (
		<ErrorMessage
			message={error && !("properties" in error) ? error?.message : null}
		/>
	);
};

export const FormButton: FC<ButtonProps> = ({ children, ...props }) => {
	const { isPending } = use(MutationFormContext);

	return (
		<Button actionType="submit" pending={isPending} {...props}>
			{children}
		</Button>
	);
};
