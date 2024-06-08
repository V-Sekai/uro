"use client";

import Image from "next/image";
import Link from "next/link";
import { X } from "lucide-react";
import { twMerge } from "tailwind-merge";

import { InlineLink } from "~/components/link";
import { useOptionalSession } from "~/hooks/session";
import Logo from "~/assets/v-sekai.png";
import { urls } from "~/environment";
import { useLocalStorage } from "~/hooks/local-storage";

import type { FC, PropsWithChildren } from "react";

const Banner: FC<PropsWithChildren<{ id: string; href: string }>> = ({
	id,
	href,
	children
}) => {
	const [closed, setClosed] = useLocalStorage(`banner.${id}.closed`, {
		initial: true,
		fallback: false
	});

	return (
		<div
			className={twMerge(
				"relative block overflow-hidden bg-blue-700/10 text-center transition-all hover:bg-blue-700/15",
				closed ? "h-0 p-0" : "p-4"
			)}
		>
			<Link className="before:absolute before:inset-0" href={href}>
				{children}
			</Link>
			<button
				className="absolute inset-y-0 right-0 my-auto mr-8 h-fit"
				type="button"
				onClick={() => setClosed(true)}
			>
				<X className="size-5" />
			</button>
		</div>
	);
};

export const Header: FC = () => {
	const session = useOptionalSession();

	return (
		<header className="flex flex-col gap-4 border-b-2 border-black/5 bg-black/[2%]">
			<Banner href={urls.discord} id="interested-in-v-sekai">
				<span className="text-blue-700">
					Interested in <span className="font-medium">V-Sekai</span> or{" "}
					<span className="font-medium">#GodotVR</span> development? Join the
					V-Sekai Discord Server!
				</span>
			</Banner>
			<div className="mx-auto flex w-full max-w-screen-lg justify-between gap-8 p-4">
				<Link className="flex h-fit shrink-0 items-center gap-4" href="/">
					<Image alt="V-Sekai Logo" className="size-12 shrink-0" src={Logo} />
					<span className="hidden text-xl font-medium sm:inline">V-Sekai</span>
				</Link>
				<nav className="flex flex-col items-end gap-2">
					<div className="flex items-center gap-2 text-sm">
						{session ? (
							<>
								<span className="mr-2">
									Logged in as{" "}
									<InlineLink
										className="font-medium"
										href={`/user?id=${session.user.username}`}
									>
										{session.user.display_name}
									</InlineLink>
								</span>
								<Link
									className="whitespace-nowrap rounded-xl bg-red-500 px-4 py-1 text-white transition-all hover:bg-red-600"
									href="/logout"
								>
									Sign out
								</Link>
							</>
						) : (
							<>
								<Link
									className="whitespace-nowrap rounded-xl bg-red-500 px-4 py-1 text-white transition-all hover:bg-red-600"
									href="/login"
								>
									Sign In
								</Link>
								<Link
									className="whitespace-nowrap rounded-xl bg-red-500 px-4 py-1 text-white transition-all hover:bg-red-600"
									href="/sign-up"
								>
									Register
								</Link>
							</>
						)}
					</div>
					<div className="flex gap-4">
						<Link href="/about">About</Link>
						<Link href="/download">Download</Link>
					</div>
				</nav>
			</div>
		</header>
	);
};
