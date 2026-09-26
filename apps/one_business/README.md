# One Business (owner app)

For business owners and their teams. Everything sits behind One ID sign-in; the router sends signed-out
people to `/sign-in`. After sign-in: a store switcher in the app bar listing every store the person can manage
(`GET /api/v1/accounts/stores`), Home with those stores (or the one picked), and Inbox, Books and Insights,
which state plainly when they arrive rather than showing sample data.

See the workspace README for running, flavours and One ID client registration.
