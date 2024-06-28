"use client";

import { useMutation } from "@tanstack/react-query";

import { type LoginCredentials, api } from "~/api";
import { useLocation } from "~/hooks/location";
import { Button } from "~/components/button";
import { Input } from "~/components/input";
import { HorizontalSeparator } from "~/components/horizontal-separator";
import { useReturnIntent } from "~/hooks/return-intent";
import { InlineLink } from "~/components/link";
import { VSekaiMark } from "~/components/vsekai-mark";

import { OAuth2ButtonGroup } from "./oauth2-button";
import { ErrorMessage } from "./error-message";

import type { FC } from "react";

export const LoginForm: FC = () => {
	const location = useLocation();
	const { withReturnIntent } = useReturnIntent();

	const email = location.searchParams.get("email");

	const { mutate, error: _error } = useMutation({
		mutationKey: ["login"],
		mutationFn: async (credentials: LoginCredentials) => {
			const { data, error } = await api.login({ body: credentials });

			if (error) throw error;
			return data;
		}
	});

	const error =
		_error ||
		(location.searchParams.has("error")
			? {
					message:
						location.searchParams.get("error_description") ||
						location.searchParams.get("error")
				}
			: null);

	return (
		<form
			className="grid w-[32rem] overflow-hidden rounded-xl border border-tertiary-300 bg-tertiary-50"
			action={(form) =>
				mutate(Object.fromEntries(form.entries()) as LoginCredentials)
			}
		>
			<div className="flex flex-col gap-8 p-8">
				<span className="text-xl">
					<VSekaiMark className="inline size-5" /> Login
				</span>
				<OAuth2ButtonGroup />
				<HorizontalSeparator>or</HorizontalSeparator>
				<div className="flex flex-col gap-4">
					<Input
						defaultValue={email || ""}
						label="Email or Username"
						name="username_or_email"
					/>
					<Input label="Password" name="password" type="password" />
				</div>
				<div className="flex flex-col gap-4">
					<ErrorMessage message={error?.message} />
					<Button actionType="submit" size="large">
						Continue
					</Button>
					<p className="opacity-75">
						Don&apos;t have an account yet?{" "}
						<InlineLink href={withReturnIntent("/sign-up")}>
							Create one
						</InlineLink>
						.
					</p>
				</div>
			</div>
		</form>
	);
};
