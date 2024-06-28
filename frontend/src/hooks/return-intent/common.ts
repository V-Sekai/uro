import { redirect } from "next/navigation";

import { firstPartyOrigins, origin } from "~/environment";

/**
 * Redirects the user to the return intent, if it is a first-party origin, otherwise to the home page.
 * @see https://www.fastly.com/blog/open-redirects-real-world-abuse-and-recommendations/
 */
export function restoreReturnIntent(ri: string) {
	const returnIntent = new URL(ri, origin);

	if (!firstPartyOrigins.has(returnIntent.origin)) return redirect("/");
	redirect(returnIntent.href);
}
