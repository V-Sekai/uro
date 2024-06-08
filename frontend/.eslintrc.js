require("@ariesclark/eslint-config/eslint-patch");
process.env["ESLINT_PROJECT_ROOT"] = __dirname;

/**
 * @type {import("eslint").Linter.Config}
 */
module.exports = {
	root: true,
	extends: [
		"@ariesclark/eslint-config",
		"@ariesclark/eslint-config/next",
		"@ariesclark/eslint-config/tailwindcss"
	],
	settings: {
		react: {
			version: "detect"
		}
	}
};
