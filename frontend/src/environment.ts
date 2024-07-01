function environment<T>(value: unknown, name: string): T {
	if (!value) throw new Error(`Missing environment variable: ${name}.`);
	return value as T;
}

export const development = process.env.NODE_ENV === "development";

export const origin = environment<string>(
	process.env.NEXT_PUBLIC_ORIGIN,
	"NEXT_PUBLIC_ORIGIN"
);

export const apiOrigin = environment<string>(
	process.env.API_ORIGIN || process.env.NEXT_PUBLIC_API_ORIGIN,
	"API_ORIGIN and or NEXT_PUBLIC_API_ORIGIN"
);

export const turnstileSiteKey = environment<string>(
	process.env.NEXT_PUBLIC_TURNSTILE_SITEKEY,
	"NEXT_PUBLIC_TURNSTILE_SITEKEY"
);

if (development) {
	process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0";
}

export const urls = {
	twitter: "https://twitter.com/vsekaiofficial",
	discord: "https://discord.gg/7BQDHesck8",
	github: "https://github.com/v-sekai"
};

/**
 * A set of first-party origins, these are given special treatment in the
 * application, such as in OAuth2 redirection & opening links in a new tab.
 */
export const firstPartyOrigins = new Set([origin]);
