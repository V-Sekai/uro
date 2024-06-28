"use client";

import { X } from "lucide-react";
import { twMerge } from "tailwind-merge";
// import { cookies } from "next/headers";

import { Link } from "../link";

import type { FC, PropsWithChildren, ReactNode } from "react";

export const unknownBannerState = { id: null, closedAt: null };

export interface BannerState {
	id: string | null;
	closedAt: number | null;
}

interface BannerProps {
	href?: string;
	onClick?: () => void;
	className?: string;
	state?: BannerState;
	actions?: ReactNode;
}

export function Banner({
	href,
	onClick,
	className,
	state: { id, closedAt = null } = unknownBannerState,
	children,
	actions
}: PropsWithChildren<BannerProps>) {
	const closable = !!id;
	const hoverable = !!(href || onClick);

	const closed = closable && closedAt !== null;
	if (closed) return null;

	const Component = href ? Link : "div";

	return (
		<div
			// eslint-disable-next-line tailwindcss/no-custom-classname
			className={twMerge(
				"dark:light dark block overflow-hidden bg-tertiary-100 text-secondary-100 lg:text-center",
				hoverable && "transition-all hover:bg-tertiary-200",
				className
			)}
		>
			<form className="relative mx-auto w-full max-w-screen-xl p-4 lg:items-center">
				<Component
					className="before:absolute before:inset-0"
					// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
					href={href!}
					onClick={onClick}
				>
					{children}
				</Component>
				{actions && (
					<div className="absolute inset-y-0 right-4 my-auto hidden h-fit gap-2 md:flex">
						{actions}
					</div>
				)}
			</form>
		</div>
	);
}

export const ClosableBannerAction: FC = () => {
	return (
		<button
			type="button"
			/* type="submit"
	formAction={async () => {
		"use server";

		cookies().set(
			`banner-${id}`,
			JSON.stringify({ closedAt: Date.now() })
		);
	}} */
		>
			<X className="size-5" />
		</button>
	);
};
