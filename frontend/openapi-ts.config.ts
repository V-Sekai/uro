import { defineConfig } from "@hey-api/openapi-ts";

process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0";

export default defineConfig({
	input: "https://vsekai.local/api/v1/",
	output: "src/__generated/api",
	client: "@hey-api/client-fetch",
	schemas: false
});
