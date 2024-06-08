"use client";

import Link from "next/link";
import { twMerge } from "tailwind-merge";
import { useEffect, useState, type ComponentProps, type FC } from "react";

export const InlineLink: FC<
	Omit<ComponentProps<typeof Link>, "href"> & { href: string }
> = ({ href, children, className, ...props }) => {
	const [external, setExternal] = useState(false);

	useEffect(
		() =>
			setExternal(
				new URL(href, window.location.origin).origin !== window.location.origin
			),
		[href]
	);

	return (
		<Link
			href={href}
			target={external ? "_blank" : undefined}
			className={twMerge(
				"text-red-500 transition-all hover:text-red-600",
				className
			)}
			{...props}
		>
			{children}
		</Link>
	);
};
