docker run -it --rm \
    -e OUTPUT_BUCKET=$OUTPUT_BUCKET \
    -e OUTPUT_PREFIX=$OUTPUT_PREFIX \
    -e AWS_PROFILE=$AWS_PROFILE \
    -v ~/.aws:/home/nonroot/.aws \
    $REPO_URL