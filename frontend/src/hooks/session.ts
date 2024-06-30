"use client";

import { useQueryClient, useSuspenseQuery } from "@tanstack/react-query";
import { redirect } from "next/dist/client/components/redirect";

import { logout as _logout } from "~/api";
import { getOptionalSession } from "~/data/session";
import { getQueryClient } from "~/query";

import { useReturnIntent } from "./return-intent";
import { useLocation } from "./location";

export const useOptionalSession = () => {
	const { withReturnIntent } = useReturnIntent();
	const { pathname } = useLocation();
	const queryClient = useQueryClient();

	const { data: session } = useSuspenseQuery({
		queryKey: ["session"],
		queryFn: async () => {
			const data = await getOptionalSession();
			if (!data) return null;

			queryClient.setQueryData(["users", data.user.username], data.user);
			return data;
		},
		refetchOnWindowFocus: "always"
	});

	if (
		session &&
		!session.user.email_confirmed_at &&
		pathname !== "/confirm-email"
	)
		redirect(withReturnIntent("/confirm-email").href);

	return session;
};

export const useSession = () => {
	const { withReturnIntent } = useReturnIntent();
	const session = useOptionalSession();

	if (!session) redirect(withReturnIntent("/login").href);

	return session;
};

export async function logout() {
	getQueryClient().setQueryData(["session"], null);
	await _logout().catch(() => {});
}
