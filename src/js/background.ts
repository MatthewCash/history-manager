import browser from 'webextension-polyfill';

const clearStaleHistory = async () => {
    const endTime = Date.now() - 2.628e9; // 1 month ago

    const [oldHistoryItems, tabs] = await Promise.all([
        browser.history.search({
            endTime,
            startTime: 0,
            text: '',
            maxResults: 1000
        }),
        browser.tabs.query({})
    ]);

    const openUrls = tabs.map(({ url }) => url);

    const staleHistoryItems = oldHistoryItems.filter(
        ({ url }) => !openUrls.includes(url)
    );

    if (!staleHistoryItems.length) return;

    console.log(`Clearing ${staleHistoryItems.length} history items:`, {
        staleHistoryItems
    });

    staleHistoryItems.forEach(
        ({ url }) => url && browser.history.deleteUrl({ url })
    );
};

setInterval(clearStaleHistory, 300000);
