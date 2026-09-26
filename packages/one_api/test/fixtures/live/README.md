Bodies captured from core-api on :4100 (One-0 seed data) on 2026-09-26:

    curl localhost:4100/api/v1/health                    > health.json
    curl localhost:4100/api/v1/health/ready              > health_ready.json
    curl 'localhost:4100/api/v1/marketplace/search?pageSize=4'   > search.json
    curl 'localhost:4100/api/v1/marketplace/search?q=zzzzqqq'    > search_empty.json
    curl localhost:4100/api/v1/marketplace/listings/<id>         > listing_detail.json
    curl localhost:4100/api/v1/marketplace/listings/<unknown id> > listing_not_found.json
    curl localhost:4100/api/v1/marketplace/listings/not-a-uuid   > listing_bad_id.json
    curl -H 'Authorization: Bearer <one-business token for ada@kolanut.ng>' \
         localhost:4100/api/v1/accounts/stores                   > accounts_stores.json

The token came from a real authorization code + PKCE exchange as the
`one-business` native client. Re-capture when core-api's responses change.
