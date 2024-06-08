"use client";

import Image from "next/image";
import { useSearchParams } from "next/navigation";
import useSWR from "swr";
import { redirect } from "next/dist/client/components/redirect";

import { getUser, type GetUserData } from "~/api";
import { useOptionalSession } from "~/hooks/session";

// eslint-disable-next-line @typescript-eslint/ban-types
type UserId = "@me" | (string & {});

function useUser(id: UserId, query: GetUserData["query"] = {}) {
	const { data = null } = useSWR(
		["user", id, query],
		async () => {
			const { data, error } = await getUser({ path: { id }, query });

			if (error?.status === 404) return null;
			if (error || !data) throw error;

			return data;
		},
		{
			fallbackData: null
		}
	);

	return data;
}

export default function ProfilePage() {
	console.log(useSearchParams());
	const username = useSearchParams().get("id") as string;

	const user = useUser(username, { username: true });
	if (!user) return null;

	return (
		<main>
			<div
				className="aspect-[16/5] w-full bg-black/5 from-transparent to-black/50 bg-cover bg-bottom xl:aspect-auto xl:h-96"
				style={{
					backgroundImage:
						"linear-gradient(to bottom, var(--tw-gradient-stops)), url(https://files.aries.fyi/2024/05/27/ad7bebad84589ef1.png)"
				}}
			/>
			<div className="mx-auto flex w-full max-w-screen-lg flex-col gap-4 p-4">
				<div className="-mt-24 flex gap-8">
					<Image
						alt={`${user.display_name}'s profile picture`}
						className="size-36 shrink-0 rounded-xl"
						height={144}
						src={"https://files.aries.fyi/2024/05/27/be96e5b1213fbb36.jpg"}
						width={144}
					/>
					<div className="flex flex-col gap-10">
						<div className="flex flex-col text-white">
							<span className="text-4xl">{user.display_name}</span>
							<span className="leading-none">{user.username}</span>
						</div>
						<span>
							Lorem ipsum dolor sit amet consectetur adipisicing elit. Amet ipsa
							ad saepe esse velit beatae nostrum hic fugit, soluta aspernatur
							rem similique. Dolorem unde ad nisi maiores tenetur repellendus
							perspiciatis.
						</span>
					</div>
				</div>
				<pre>{JSON.stringify(user, null, 2)}</pre>
			</div>
		</main>
	);
}
