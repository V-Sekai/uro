// Expose some server env variables to client as API
export const dynamic = 'force-dynamic';

export async function GET(request) {
  const responseBody = {
    origin: process.env.NEXTJS_ORIGIN,
    apiOrigin: process.env.NEXTJS_API_ORIGIN,
    turnstileSiteKey: process.env.NEXTJS_TURNSTILE_SITEKEY,
  };

  return new Response(JSON.stringify(responseBody), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}
