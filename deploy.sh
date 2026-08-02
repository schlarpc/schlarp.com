#!/usr/bin/env bash
#
# Build the site and publish it to the S3 bucket behind the CloudFront
# distribution, then invalidate the cache.
#
# Two deliberate choices worth knowing before you change them:
#
#   * Never `aws s3 sync --delete`. The bucket also serves files/ -- several GB
#     of downloads linked from the old project pages, which this repo does not
#     produce and cannot regenerate. Retire stale keys by hand instead.
#
#   * `aws s3 cp`, not `aws s3 sync`. Every file in the Nix store carries an
#     mtime of 1970-01-01, and sync only uploads when the size differs or the
#     source is newer, so it would silently skip a changed file whose size
#     happened to match.

set -euo pipefail

STACK=${STACK:-schlarp-com}
REGION=${REGION:-us-east-1}

dryrun=()
case "${1:-}" in
    -n | --dry-run) dryrun=(--dryrun) ;;
    "") ;;
    *)
        echo "usage: $0 [--dry-run]" >&2
        exit 2
        ;;
esac

stack_output() {
    aws cloudformation describe-stacks \
        --stack-name "$STACK" --region "$REGION" \
        --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" \
        --output text
}

bucket=$(stack_output ContentBucketName)
distribution=$(stack_output DistributionId)

echo "==> Building"
nix build

echo "==> Publishing to s3://${bucket}/"
aws s3 cp "$(readlink -f result)/" "s3://${bucket}/" --recursive "${dryrun[@]}"

if [ ${#dryrun[@]} -ne 0 ]; then
    echo "==> Dry run, skipping invalidation"
    exit 0
fi

echo "==> Invalidating ${distribution}"
aws cloudfront create-invalidation \
    --distribution-id "$distribution" \
    --paths '/*' \
    --query 'Invalidation.Id' \
    --output text
