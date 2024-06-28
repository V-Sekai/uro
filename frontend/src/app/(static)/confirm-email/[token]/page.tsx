import { api } from "~/api";
import { Button } from "~/components/button";
import { VSekaiMark } from "~/components/vsekai-mark";

export default async function ConfirmEmailPage({
	params: { token }
}: {
	params: { token: string };
}) {
	const {
		response: { status }
	} = await api.confirmEmail({
		path: { id: "@me" },
		body: { token: token }
	});

	return (
		<div className="flex h-full grow items-center justify-center">
			<div className="flex w-[32rem] flex-col gap-4 overflow-hidden rounded-xl border border-tertiary-300 bg-tertiary-50 p-8">
				{status === 200 ? (
					<>
						<span className="text-xl">
							<VSekaiMark className="inline size-5" /> Email successfully
							confirmed
						</span>
						<p className="opacity-75">
							You can now close this tab, or continue using the application.
						</p>
					</>
				) : (
					<>
						<span className="text-xl">
							<VSekaiMark className="inline size-5" /> Email confirmation failed
						</span>
						<p className="opacity-75">
							Something went wrong while confirming your email address. If you
							copied the link, please make sure you{" "}
							<span className="font-medium">copied the entire URL</span> and
							that it is not expired.
						</p>
						<Button className="w-fit">Resend</Button>
					</>
				)}
			</div>
		</div>
	);
}
