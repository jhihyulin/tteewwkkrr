// 反向代理部署在coudfare workers上
// 用於解決mixed content問題

export default {
    async fetch(request, env, ctx) {
        const url = new URL(request.url);
        url.protocol = 'http:';
        url.host = 'tewkr.com';
        const response = await fetch(url, request);
        const newHeaders = new Headers(response.headers);
        newHeaders.set('Access-Control-Allow-Origin', '*');
        return new Response(response.body, {
            status: response.status,
            statusText: response.statusText,
            headers: newHeaders,
        });
    },
};
