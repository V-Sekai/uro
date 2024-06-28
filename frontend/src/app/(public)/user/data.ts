import { useSuspenseQuery } from "@tanstack/react-query";

import { getUser } from "~/api";
import { useOptionalSession } from "~/hooks/session";

export function useUser(username: string) {
	const session = useOptionalSession();

	const { data: user = null } = useSuspenseQuery({
		queryKey: ["users", username],
		queryFn:
			session?.user.username === username
				? () => session.user
				: async ({ queryKey: [, username], signal }) => {
						if (!username) return null;

						const { data, error, response } = await getUser({
							path: { id: username },
							query: { username: true },
							signal
						});

						if (response.status === 404) return null;
						if (error) throw error;
						return data;
					}
	});

	if (!user) return null;

	return {
		...user,
		banner: "https://unsplash.it/1600/900/?random",
		//"https://files.aries.fyi/cdn-cgi/image/width=1600/2024/06/19/6d5d545f74c86002.png",
		biography:
			"Lorem ipsum dolor sit amet consectetur adipisicing elit. Amet ipsa ad saepe esse velit beatae nostrum hic fugit, soluta aspernatur rem similique. Dolorem unde ad nisi maiores tenetur repellendus perspiciatis.",
		status: "available",
		statusMessage: "Available"
	};
}
