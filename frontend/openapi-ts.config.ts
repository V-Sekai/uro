import { defineConfig } from "@hey-api/openapi-ts";

export default defineConfig({
	input: "src/__generated/openapi.json",
	output: "src/__generated/api",
	client: "@hey-api/client-fetch",
	schemas: false
});
