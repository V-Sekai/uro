const development = process.env.NODE_ENV !== "production";

/** @type {import('next').NextConfig} */
const nextConfig = {
	output: "standalone",
	experimental: {
		reactCompiler: true
	},
	images: {
		unoptimized: true
	},
	rewrites: development
		? async () => {
				return {
					beforeFiles: [
						{
							source: "/users/:username",
							destination: "/user?foo=1"
						},
						{
							source: "/user/:username/:path*",
							destination: "/user/:path*?id=:username"
						}
					],
					fallback: [
						{
							source: "/:path*",
							destination: "http://localhost:4000/:path*"
						}
					]
				};
			}
		: undefined
};

export default nextConfig;
