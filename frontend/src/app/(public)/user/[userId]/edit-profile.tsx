"use client";
import { twMerge } from "tailwind-merge";
import Image from "next/image";

import { Input } from "~/components/input";
import {
	Dialog,
	DialogContent,
	DialogHeader,
	DialogTitle
} from "~/components/dialog";
import VSekaiRed from "~/assets/v-sekai-red.png";

import { useUser } from "../data";

import type { FC, PropsWithChildren } from "react";

export const EditProfile: FC<PropsWithChildren<{ userId: string }>> = ({
	userId,
	children
}) => {
	const user = useUser(userId);
	if (!user) return null;

	const { username, display_name, avatar, banner, biography } = user;

	return (
		<Dialog>
			{children}
			<DialogContent className="light">
				<DialogHeader>
					<DialogTitle>Edit profile</DialogTitle>
					<button
						type="button"
						className={twMerge(
							"-my-4 flex items-center gap-2 rounded-xl border border-black/20 bg-black/5 px-4 py-1"
						)}
					>
						Save
					</button>
				</DialogHeader>
				<div className="-mx-6 flex flex-col">
					<div
						className="aspect-[16/4] w-full bg-cover bg-center"
						style={{
							backgroundImage: banner ? `url(${banner})` : undefined
						}}
					/>
					<div className="-mt-12 flex items-center gap-4 px-6">
						<Image
							priority
							alt={`${user.display_name}'s profile picture`}
							className="size-24 shrink-0 rounded-xl"
							height={144}
							src={avatar || VSekaiRed.src}
							width={144}
						/>
						<div className="flex h-fit w-28 max-w-fit items-center gap-2 overflow-hidden rounded-xl border border-black/5 bg-white pr-3 transition-all">
							<div className="aspect-square size-6 shrink-0 rounded-full bg-blue-400" />
							<span className="whitespace-nowrap text-sm">Available</span>
						</div>
					</div>
				</div>
				<Input defaultValue={display_name} label="Display Name" />
				<Input multiline defaultValue={biography} label="Biography" />
				<Input defaultValue={username} label="Username (cannot be changed)" />
			</DialogContent>
		</Dialog>
	);
};
