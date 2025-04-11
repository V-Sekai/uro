// Expose some server env variables to client as API
export const dynamic = 'force-dynamic';

export async function GET(request) {
  const responseBody = {
  };

  return new Response(JSON.stringify(responseBody), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}
