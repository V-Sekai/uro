import { usePathname, useSearchParams } from "next/navigation";

import { origin } from "~/environment";

type Location = URL & { current: string };

/**
 * A combination of {@link usePathname} and {@link useSearchParams}.
 */
export function useLocation(): Location {
	const pathname = usePathname();
	const searchParameters = useSearchParams();

	const current = `${pathname}${searchParameters.size > 0 ? `?${searchParameters.toString()}` : ""}`;
	return Object.assign(new URL(current, origin), { current });
}
