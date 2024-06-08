import { defineConfig } from "@hey-api/openapi-ts";

export default defineConfig({
	input: "http://localhost:4000/api/v1",
	output: "src/__generated/api",
	client: "@hey-api/client-fetch"
});
