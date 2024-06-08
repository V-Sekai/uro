"use client";

import { redirect, useSearchParams } from "next/navigation";
import {
	Suspense,
	type ComponentProps,
	type JSXElementConstructor,
	type PropsWithChildren
} from "react";

import { useOptionalSession } from "../../hooks/session";

function GuestLayout({ children }: PropsWithChildren) {
	const session = useOptionalSession();

	const to = useSearchParams().get("to") || "/";
	if (session) redirect(to);

	return children;
}

export default withSuspense(GuestLayout);

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function withSuspense<T extends JSXElementConstructor<any>>(Component: T) {
	return function WithSuspense(props: ComponentProps<T>) {
		return (
			<Suspense fallback={<span>Loading...</span>}>
				<Component {...props} />
			</Suspense>
		);
	};
}
