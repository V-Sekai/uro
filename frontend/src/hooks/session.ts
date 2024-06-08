import { redirect } from "next/dist/client/components/redirect";
import { usePathname } from "next/navigation";
import useSWR from "swr";

import { session } from "~/api";

const invalidCredentials = "Invalid credentials.";

export const useOptionalSession = () => {
	const { data } = useSWR(
		"session",
		async () => {
			const { data, error } = await session();
			if (error?.status === 401 && error?.message === invalidCredentials)
				return null;

			if (error) throw error;
			return data || null;
		},
		{ fallbackData: null }
	);

	return data;
};

export const useSession = () => {
	const session = useOptionalSession();
	const pathname = usePathname();

	if (!session) redirect(`/login?to=${pathname}`);

	return session;
};
