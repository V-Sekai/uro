"use client";

import { TriangleAlert } from "lucide-react";
import useSWRMutation from "swr/mutation";

import { login, type LoginCredentials } from "~/api";

import type { FC } from "react";

const ErrorMessage: FC<{ message?: string | null }> = ({ message }) => {
	if (!message) return null;

	return (
		<div className="whitespace-break-spaces rounded-md border border-red-500/5 bg-red-500/5 px-4 py-2 text-sm text-red-500">
			<TriangleAlert className="mr-2 inline-block size-4" />
			{message}
		</div>
	);
};

export default function LoginPage() {
	const { data: { error } = {}, trigger } = useSWRMutation(
		"session",
		(_, { arg: credentials }: { arg: LoginCredentials }) =>
			login({ body: credentials }),
		{
			populateCache: ({ data = null }) => data,
			revalidate: false
		}
	);

	return (
		<div className="flex h-full grow items-center justify-center">
			<form
				className="grid w-[32rem] overflow-hidden rounded-lg border border-black/10"
				action={(form) =>
					trigger(Object.fromEntries(form.entries()) as LoginCredentials)
				}
			>
				<div className="flex flex-col gap-8 p-8">
					<span className="text-xl">Login</span>
					<div className="flex flex-col gap-4">
						<label className="flex flex-col gap-1">
							<span className="text-sm font-medium">Email or Username</span>
							<input
								autoComplete="username"
								className="rounded-md border border-black/20 px-4 py-2 focus-within:bg-black/5"
								name="username_or_email"
								type="text"
							/>
						</label>
						<label className="flex flex-col gap-1">
							<span className="text-sm font-medium">Password</span>
							<input
								className="rounded-md border border-black/20 px-4 py-2 focus-within:bg-black/5"
								name="password"
								type="password"
							/>
						</label>
					</div>
					<div className="flex flex-col gap-4">
						<ErrorMessage message={error?.message} />

						<button
							className="rounded-md bg-red-500 p-4 text-sm font-medium text-white"
							type="submit"
						>
							Continue
						</button>
					</div>
				</div>
			</form>
		</div>
	);
}
