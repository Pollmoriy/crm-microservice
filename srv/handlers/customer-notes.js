module.exports = function registerCustomerNoteHandlers(srv) {
    srv.before('CREATE', 'CustomerNotes', async (req) => {
        req.data.authorID = req.user.id;
        if (!req.data.date) {
            req.data.date = new Date().toISOString().slice(0, 10);
        }
    });
};