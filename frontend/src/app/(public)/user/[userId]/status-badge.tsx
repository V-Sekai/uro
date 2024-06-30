import { twMerge } from "tailwind-merge";

import type { FC } from "react";
import type { api } from "~/api";

const statusMetadata: Record<
	api.UserStatus,
	{ message: string; className: string }
> = {
	online: {
		message: "Online",
		className: "bg-green-500"
	},
	offline: {
		message: "Offline",
		className: "bg-gray-500"
	},
	away: {
		message: "Away",
		className: "bg-yellow-500"
	},
	busy: {
		message: "Busy",
		className: "bg-red-500"
	},
	invisible: {
		message: "Offline",
		className: "bg-gray-500"
	}
};

export const StatusBadge: FC<{
	user: Pick<api.User, "status" | "status_message">;
}> = ({ user: { status, status_message } }) => {
	if (!status || ["offline", "invisible"].includes(status)) return null;
	const { message: defaultStatusMessage, className: statusClassName } =
		statusMetadata[status];

	return (
		<div className="flex w-28 max-w-fit items-center gap-2 overflow-hidden rounded-xl border border-tertiary-300 bg-tertiary-50 pr-3 transition-all">
			<div
				className={twMerge(
					"aspect-square size-6 shrink-0 rounded-full",
					statusClassName
				)}
			/>
			<span className="whitespace-nowrap text-sm">
				{status_message || defaultStatusMessage}
			</span>
		</div>
	);
};
