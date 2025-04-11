import { env } from 'next-runtime-env';

function environment<T>(value: unknown, name: string): T {
	if (!value) throw new Error(`Missing environment variable: ${name}.`);
	return value as T;
}

export const development = process.env.NODE_ENV === "development";

if (development) {
	process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0";
}

export const urls = {
	discord: "https://discord.gg/7BQDHesck8",
	github: "https://github.com/v-sekai",
	twitter: "https://twitter.com/vsekaiofficial"
};

// Runtime fetch from API
interface serverEnvType {
	origin: string;
	apiOrigin: string;
	turnstileSiteKey: string
};

let envCache: serverEnvType | null = null;

export const getServerEnv = (): serverEnvType | null => {
  if (envCache) {
    // console.log("Using cached env:", envCache);
    return envCache;
  }

  // Server-side
  if (typeof window === "undefined") {
    const serverEnv = {
        origin: environment<string>(
            process.env.ORIGIN || process.env.NEXT_PUBLIC_ORIGIN,
            "NEXT_PUBLIC_ORIGIN"
        ),
        apiOrigin: environment<string>( // API_ORIGIN is only used server-side
            process.env.API_ORIGIN || process.env.NEXT_PUBLIC_API_ORIGIN,
            "API_ORIGIN and or NEXT_PUBLIC_API_ORIGIN"
        ),
        turnstileSiteKey: environment<string>(
            process.env.TURNSTILE_SITEKEY || process.env.NEXT_PUBLIC_TURNSTILE_SITEKEY,
            "NEXT_PUBLIC_TURNSTILE_SITEKEY"
        )
    };

    envCache = serverEnv;
    // console.log("Fetched environment on server side.");
    return serverEnv;
  }

  // Client-side
  try {
    //const xhr = new XMLHttpRequest();
    //let timeout = setTimeout(function () {
    //    xhr.abort();
    //    console.error("Request timed out");
    //}, 5000);
	  
    //xhr.open("GET", "/api/env", false); // Synchronous XMLHttpRequest
    //xhr.send();
    //clearTimeout(timeout);
    const clientEnv = {
      origin: environment<string>(env("NEXT_PUBLIC_ORIGIN"), "NEXT_PUBLIC_ORIGIN"),
      apiOrigin: environment<string>(env("NEXT_PUBLIC_API_ORIGIN"), "NEXT_PUBLIC_API_ORIGIN"),
      turnstileSiteKey: environment<string>(env("NEXT_PUBLIC_TURNSTILE_SITEKEY"), "NEXT_PUBLIC_TURNSTILE_SITEKEY"),
    };
    //if (xhr.status === 200) {
    //  envCache = JSON.parse(xhr.responseText);
    //  // console.log("Fetched serverEnv:", envCache);
    //  return envCache;
    //} else {
    //  console.error(`Failed to fetch server environment: ${xhr.status}`);
    //}
    return clientEnv;
  } catch (error) {
    console.error("Error fetching server environment:", String(error));
  }

  return null;
};

/**
 * A set of first-party origins, these are given special treatment in the
 * application, such as in OAuth2 redirection & opening links in a new tab.
 * Add to set below if required.
 */
const firstPartyOrigins: Set<string> = new Set([]);

export const getFirstPartyOrigins = (): Set<string> => {
  const appOrigin = getServerEnv()?.origin;
  let origins = firstPartyOrigins;

  // Ensure firstPartyOrigins includes the fetched origin
  if (appOrigin) {
    origins.add(appOrigin);
  }

  // console.log("First-party origins:", [...origins]);
  return origins;
};
