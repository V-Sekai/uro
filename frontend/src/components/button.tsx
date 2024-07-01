/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-non-null-assertion */
"use client";

import {
	forwardRef,
	useState,
	type ButtonHTMLAttributes,
	type ForwardedRef,
	type PropsWithChildren
} from "react";
import { tv, type VariantProps } from "tailwind-variants";

import { dataAttribute } from "~/element";

import { Link } from "./link";

export const button = tv({
	base: [
		"flex items-center justify-center whitespace-nowrap transition-all",
		"outline-current outline-offset-2 focus-visible:outline",
		"rounded-xl group-data-[button-group]:rounded-none group-data-[button-group]:first:rounded-l-xl group-data-[button-group]:last:rounded-r-xl",
		"border border-transparent group-data-[button-group]:first:border-l group-data-[button-group]:border-x-0 group-data-[button-group]:last:border-r",
		"data-[pressed]:scale-[.97] group-data-[button-group]:first:origin-right group-data-[button-group]:last:origin-left"
	],
	variants: {
		type: {
			primary: "bg-red-500 text-white hover:bg-red-600",
			light:
				"border-secondary-0/20 bg-secondary-0/5 text-secondary-0 backdrop-blur aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
			ghost: "text-secondary-100"
		},
		size: {
			small: "text-sm gap-2 px-2 py-1",
			medium: "text-base px-4 gap-2 py-1",
			large: "text-base px-6 gap-3 py-3"
		},
		iconOnly: {
			true: "!p-2"
		},
		disabled: {
			true: "opacity-50 pointer-events-none"
		},
		pending: {
			true: "animate-pulse pointer-events-none"
		}
	},
	defaultVariants: {
		type: "primary",
		size: "medium",
		iconOnly: false,
		disabled: false,
		pending: false
	}
});

export type ButtonProps = PropsWithChildren<
	VariantProps<typeof button> & {
		href?: string | URL;
		onClick?: () => void;
		className?: string;
		actionType?: ButtonHTMLAttributes<HTMLButtonElement>["type"];
	}
>;

export const Button = forwardRef<HTMLElement, ButtonProps>(
	(
		{ onClick, href, actionType = "button", disabled, children, ...tvProps },
		reference
	) => {
		const [pressed, setPressed] = useState(false);

		const Component = href ? Link : "button";

		return (
			<Component
				className={button({ disabled, ...tvProps })}
				data-pressed={dataAttribute(pressed)}
				disabled={disabled}
				href={href!}
				ref={reference as ForwardedRef<any>}
				type={actionType}
				onClick={onClick}
				onPointerDown={() => setPressed(true)}
				onPointerOut={() => setPressed(false)}
				onPointerUp={() => setPressed(false)}
			>
				{children}
			</Component>
		);
	}
);

Button.displayName = "Button";

export const buttonGroup = tv({
	base: "group flex rounded-xl",
	variants: {
		direction: {
			horizontal: "flex-row",
			vertical: "flex-col"
		}
	},
	defaultVariants: {
		direction: "horizontal"
	}
});

export type ButtonGroupProps = { className?: string } & PropsWithChildren<
	VariantProps<typeof buttonGroup>
>;

export const ButtonGroup = forwardRef<HTMLDivElement, ButtonGroupProps>(
	({ children, ...tvProps }, reference) => {
		return (
			<div
				className={buttonGroup(tvProps)}
				data-button-group=""
				ref={reference}
			>
				{children}
			</div>
		);
	}
);

ButtonGroup.displayName = "Button.Group";
