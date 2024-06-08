"use client";

import { useEffect } from "react";
import useSWRMutation from "swr/mutation";

import { logout } from "~/api";

export default function LogoutPage() {
	const { trigger } = useSWRMutation("session", () => logout(), {
		populateCache: () => null,
		revalidate: false
	});

	useEffect(() => void trigger(), [trigger]);
}
