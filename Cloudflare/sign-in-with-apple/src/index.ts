import * as jose from 'jose';

/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Bind resources to your worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
	async fetch(request, env, ctx): Promise<Response> {
		const url = new URL(request.url);

		if (url.pathname === '/login/apple' && request.method === 'POST') {
			let body: any;
			console.log('=====xvvvv', request)
			try {
				body = await request.json();
			} catch {
				return jsonResponse({ error: 'Invalid JSON' }, 400);
			}

			console.log('=====x', body)


			return jsonResponse({ rsp: "askdf000"})
		}


		const { pathname } = new URL(request.url);

		if (pathname === "/api/beverages") {
			// If you did not use `DB` as your binding name, change it here
			const { results } = await env.db_prod
				.prepare("SELECT * FROM users WHERE email = ?")
				.bind("Bs Beverages")
				.run();
			return Response.json(results);
		}

		return new Response(
			"Call /api/beverages to see everyone who works at Bs Beverages",
		);
	},
} satisfies ExportedHandler<Env>;

function jsonResponse(data: any, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}