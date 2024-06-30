import { useSuspenseQuery } from "@tanstack/react-query";

import { type api, getUser, type User } from "~/api";
import { useOptionalSession } from "~/hooks/session";
import { getQueryClient } from "~/query";

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
		banner: "https://unsplash.it/1600/900/?random"
	};
}

export function invalidateUser(user: User) {
	const queryClient = getQueryClient();
	const session = queryClient.getQueryData<api.Session>(["session"]);

	queryClient.setQueryData(["users", user.id], user);
	queryClient.setQueryData(["users", user.username], user);

	if (session && session.user.id === user.id)
		queryClient.setQueryData(["session"], (previous: api.Session) => ({
			...previous,
			user
		}));
}
