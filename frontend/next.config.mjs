/** @type {import('next').NextConfig} */
const nextConfig = {
	output: "standalone",
	experimental: {
		// reactCompiler: true,
		// turbotrace: {}
	},
	images: {
		unoptimized: true
	},
	rewrites: async () => {
		return {
			afterFiles: [
				{
					source: "/@:username/:path*",
					destination: "/user/:username/:path*"
				}
			]
		};
	}
};

export default nextConfig;
