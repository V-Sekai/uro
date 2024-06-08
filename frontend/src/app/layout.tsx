"use client";

import { Prompt } from "next/font/google";
import { SWRConfig } from "swr";
import { twMerge } from "tailwind-merge";

import { Header } from "./header";

// import type { Metadata } from "next";

import "./globals.css";

const montserrat = Prompt({
	subsets: ["latin"],
	weight: ["100", "200", "300", "400", "500", "600", "700", "800", "900"]
});

/* export const metadata: Metadata = {
	title: "V-Sekai",
	description: "Your virtual reality platform, on your game engine."
}; */

export default function RootLayout({
	children
}: Readonly<{
	children: React.ReactNode;
}>) {
	return (
		<html lang="en">
			<head>
				<script>{"{{ inject phoenix }}"}</script>
				<script>{`hello = "world"`}</script>
			</head>
			<body
				className={twMerge("flex min-h-svh flex-col", montserrat.className)}
			>
				<SWRConfig
					value={(...config) => ({
						...config,
						suspense: true
					})}
				>
					<Header />
					{children}
				</SWRConfig>
			</body>
		</html>
	);
}
