/**
 * @type {import("tailwindcss").Config}
 */
export default {
	content: [
		"./src/components/**/*.{js,ts,jsx,tsx,mdx}",
		"./src/app/**/*.{js,ts,jsx,tsx,mdx}"
	],
	darkMode: "class",
	plugins: [require("tailwindcss-animate")],
	theme: {
		extend: {
			colors: {
				secondary: {
					0: "var(--secondary-0)",
					100: "var(--secondary-100)"
				},
				tertiary: {
					0: "var(--tertiary-0)",
					100: "var(--tertiary-100)",
					200: "var(--tertiary-200)",
					300: "var(--tertiary-300)",
					400: "var(--tertiary-400)",
					50: "var(--tertiary-50)",
					500: "var(--tertiary-500)",
					600: "var(--tertiary-600)",
					700: "var(--tertiary-700)",
					800: "var(--tertiary-800)",
					900: "var(--tertiary-900)",
					950: "var(--tertiary-950)"
				}
			},
			opacity: {
				1: "1%",
				2: "2%",
				3: "3%",
				4: "4%"
			}
		},
		fontWeight: {
			medium: "500",
			normal: "400"
		}
	}
};
