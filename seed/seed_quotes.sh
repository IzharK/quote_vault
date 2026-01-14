#!/usr/bin/env bash
set -e

SUPABASE_URL="$SUPABASE_URL"
SUPABASE_KEY="$SUPABASE_SERVICE_KEY"

MAX_PAGES=150
PAGE_LIMIT=150
BATCH_SIZE=100

if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_KEY" ]]; then
  echo "❌ Missing SUPABASE_URL or SUPABASE_SERVICE_KEY"
  exit 1
fi

echo "🚀 Starting quote seeding..."

declare -A TAG_MAP=(
  # Wisdom
  [age]=Wisdom [change]=Wisdom [character]=Wisdom [education]=Wisdom
  [ethics]=Wisdom [faith]=Wisdom [freedom]=Wisdom [future]=Wisdom
  [generosity]=Wisdom [genius]=Wisdom [gratitude]=Wisdom
  [happiness]=Wisdom [health]=Wisdom [history]=Wisdom
  [honor]=Wisdom [knowledge]=Wisdom [life]=Wisdom
  [literature]=Wisdom [nature]=Wisdom [pain]=Wisdom
  [philosophy]=Wisdom [politics]=Wisdom [proverb]=Wisdom
  [religion]=Wisdom [science]=Wisdom [society]=Wisdom
  [spirituality]=Wisdom [time]=Wisdom [tolerance]=Wisdom
  [truth]=Wisdom [virtue]=Wisdom [war]=Wisdom
  [wellness]=Wisdom [wisdom]=Wisdom

  # Motivation
  [athletics]=Motivation [competition]=Motivation [courage]=Motivation
  [creativity]=Motivation [failure]=Motivation [inspirational]=Motivation
  [leadership]=Motivation [motivational]=Motivation
  [opportunity]=Motivation [perseverance]=Motivation
  [power-quotes]=Motivation [self]=Motivation
  [self-help]=Motivation [sports]=Motivation
  [weakness]=Motivation [work]=Motivation

  # Success
  [business]=Success [success]=Success [technology]=Success

  # Love
  [family]=Love [friendship]=Love [love]=Love [sadness]=Love

  # Humor
  [humor]=Humor [humorous]=Humor [film]=Humor
  [stupidity]=Humor [famous-quotes]=Humor
)

resolve_category () {
  for tag in "$@"; do
    key=$(echo "$tag" | tr '[:upper:]' '[:lower:]')
    if [[ -n "${TAG_MAP[$key]}" ]]; then
      echo "${TAG_MAP[$key]}"
      return
    fi
  done
  echo "Wisdom"
}

insert_batch () {
  local payload="$1"
  curl -s -X POST "$SUPABASE_URL/rest/v1/quotes" \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    -H "Content-Type: application/json" \
    -H "Prefer: resolution=ignore-duplicates" \
    -d "$payload" > /dev/null
}

batch="[]"
count=0

for ((page=1; page<=MAX_PAGES; page++)); do
  echo "📄 Fetching page $page"

  response=$(curl -s \
    -H "User-Agent: quote-vault-seeder/1.0" \
    "https://api.quotable.io/quotes?limit=$PAGE_LIMIT&page=$page")

  echo "$response" | jq -c '.results[]' | while read -r q; do
    text=$(echo "$q" | jq -r '.content')
    author=$(echo "$q" | jq -r '.author')
    [[ ${#text} -lt 20 || "$author" == "null" ]] && continue

    tags=($(echo "$q" | jq -r '.tags[]?'))
    category=$(resolve_category "${tags[@]}")
    hash=$(echo -n "$text|$author" | sha1sum | awk '{print $1}')

    item=$(jq -n \
      --arg t "$text" \
      --arg a "$author" \
      --arg c "$category" \
      --arg h "$hash" \
      '{text:$t, author:$a, category:$c, content_hash:$h, source:"quotable"}')

    batch=$(echo "$batch" | jq --argjson i "$item" '. + [$i]')
    ((count++))

    if (( count % BATCH_SIZE == 0 )); then
      insert_batch "$batch"
      batch="[]"
    fi
  done
done

[[ "$batch" != "[]" ]] && insert_batch "$batch"

echo "✅ Seeding complete"
