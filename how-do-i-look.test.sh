#!/bin/bash
set -euo pipefail

############################
# Config
############################
BASE_URL="${BASE_URL:-http://localhost:8080}"
PASSWORD="test-password123"
WRONG_PASSWORD="wrong-password456"

############################
# Stats
############################
PASSED=0
FAILED=0

############################
# Utils
############################
log() {
  echo -e "\n\033[1;34m▶ $1\033[0m"
}

success() {
  echo -e "\033[1;32m✔ SUCCESS\033[0m"
  ((PASSED++)) || true
}

fail() {
  echo -e "\033[1;31m✘ FAIL: $1\033[0m"
  ((FAILED++)) || true
}

api_call() {
  local method=$1
  local endpoint=$2
  local data=${3:-}
  local max_retries=2
  local retry_count=0
  local result

  while [ $retry_count -lt $max_retries ]; do
    if [[ -n "$data" ]]; then
      printf "curl -s --connect-timeout 10 --max-time 60 -w \"\\\\n%%{http_code}\" -X %s \\\\\n  -H \"Content-Type: application/json\" \\\\\n  -d '%s' \\\\\n  %s%s\n" "$method" "$data" "$BASE_URL" "$endpoint" >&2
      result=$(curl -s --connect-timeout 10 --max-time 60 -w "\n%{http_code}" -X "$method" \
        -H "Content-Type: application/json" \
        -d "$data" \
        "$BASE_URL$endpoint" 2>/dev/null || echo -e "\n000")
    else
      printf "curl -s --connect-timeout 10 --max-time 60 -w \"\\\\n%%{http_code}\" -X %s \\\\\n  %s%s\n" "$method" "$BASE_URL" "$endpoint" >&2
      result=$(curl -s --connect-timeout 10 --max-time 60 -w "\n%{http_code}" -X "$method" \
        "$BASE_URL$endpoint" 2>/dev/null || echo -e "\n000")
    fi

    local status=$(echo "$result" | tail -1)
    if [[ "$status" != "000" ]]; then
      echo "$result"
      return 0
    fi

    ((retry_count++))
    if [ $retry_count -lt $max_retries ]; then
      echo "  ⚠ Retrying ($retry_count/$max_retries)..." >&2
      sleep 2
    fi
  done

  echo -e "\n000"
  return 1
}

check_status() {
  local expected=$1

  if [[ "$HTTP_STATUS" == "000" ]]; then
    fail "Timeout or connection error"
  elif [[ "$HTTP_STATUS" == "$expected" ]]; then
    success
  else
    fail "Expected $expected, got $HTTP_STATUS"
  fi
  return 0
}

############################
# 1. 스타일 등록
############################
log "1. Create Style (POST /styles)"
RESPONSE=$(api_call POST "/styles" "{
  \"nickname\": \"tester\",
  \"title\": \"test 스타일\",
  \"content\": \"자동화 test용 스타일\",
  \"password\": \"$PASSWORD\",
  \"categories\": {
    \"top\": { \"name\": \"셔츠\", \"brand\": \"Uniqlo\", \"price\": 30000 },
    \"bottom\": { \"name\": \"청바지\", \"brand\": \"Levis\", \"price\": 80000 }
  },
  \"tags\": [\"캐주얼\", \"테스트\"],
  \"imageUrls\": [\"https://example.com/a.jpg\"]
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo $BODY
STYLE_ID=$(echo "$BODY" | jq -r '.id')
check_status "201"

############################
# 2. 스타일 목록 조회
############################
log "2. List Styles (GET /styles)"
RESPONSE=$(api_call GET "/styles?page=1&pageSize=10")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 3. 스타일 목록 조회 (정렬)
############################
log "3. List Styles - Sort by mostViewed"
RESPONSE=$(api_call GET "/styles?page=1&pageSize=10&sortBy=mostViewed")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 4. 스타일 목록 조회 (검색)
############################
log "4. List Styles - Search by title"
RESPONSE=$(api_call GET "/styles?page=1&pageSize=10&searchBy=title&keyword=test")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 5. 스타일 목록 조회 (태그)
############################
log "5. List Styles - Filter by tag"
RESPONSE=$(api_call GET "/styles?page=1&pageSize=10&tag=캐주얼")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 6. 스타일 상세 조회
############################
log "6. Get Style Detail (GET /styles/$STYLE_ID)"
RESPONSE=$(api_call GET "/styles/$STYLE_ID")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 7. 스타일 랭킹 조회 (Total)
############################
log "7. List Style Rankings - Total"
RESPONSE=$(api_call GET "/ranking?page=1&pageSize=10&rankBy=total")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 8. 스타일 랭킹 조회 (Trendy)
############################
log "8. List Style Rankings - Trendy"
RESPONSE=$(api_call GET "/ranking?page=1&pageSize=10&rankBy=trendy")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 9. 스타일 수정
############################
log "9. Update Style (PUT /styles/$STYLE_ID)"
RESPONSE=$(api_call PUT "/styles/$STYLE_ID" "{
  \"nickname\": \"tester\",
  \"title\": \"수정된 스타일\",
  \"content\": \"수정된 내용\",
  \"password\": \"$PASSWORD\",
  \"categories\": {
    \"top\": { \"name\": \"니트\", \"brand\": \"Zara\", \"price\": 50000 },
    \"shoes\": { \"name\": \"운동화\", \"brand\": \"Nike\", \"price\": 120000 }
  },
  \"tags\": [\"수정됨\"],
  \"imageUrls\": [\"https://example.com/b.jpg\"]
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 10. 스타일 수정 (잘못된 비밀번호)
############################
log "10. Update Style - Wrong Password"
RESPONSE=$(api_call PUT "/styles/$STYLE_ID" "{
  \"nickname\": \"tester\",
  \"title\": \"수정 실패\",
  \"content\": \"수정 실패\",
  \"password\": \"$WRONG_PASSWORD\",
  \"categories\": {\"top\": {\"name\": \"니트\", \"brand\": \"Zara\", \"price\": 50000}},
  \"tags\": [\"실패\"],
  \"imageUrls\": [\"https://example.com/b.jpg\"]
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "403"

############################
# 11. 큐레이팅 등록
############################
log "11. Create Curation (POST /styles/$STYLE_ID/curations)"
RESPONSE=$(api_call POST "/styles/$STYLE_ID/curations" "{
  \"nickname\": \"curator\",
  \"content\": \"괜찮은 스타일입니다\",
  \"password\": \"$PASSWORD\",
  \"trendy\": 4,
  \"personality\": 3,
  \"practicality\": 4,
  \"costEffectiveness\": 5
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
CURATION_ID=$(echo "$BODY" | jq -r '.id')
check_status "200"

############################
# 12. 큐레이팅 목록 조회
############################
log "12. List Curations (GET /styles/$STYLE_ID/curations)"
RESPONSE=$(api_call GET "/styles/$STYLE_ID/curations?page=1&pageSize=10")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 13. 큐레이팅 목록 조회 (검색)
############################
log "13. List Curations - Search"
RESPONSE=$(api_call GET "/styles/$STYLE_ID/curations?page=1&pageSize=10&searchBy=nickname&keyword=curator")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 14. 큐레이팅 수정
############################
log "14. Update Curation (PUT /curations/$CURATION_ID)"
RESPONSE=$(api_call PUT "/curations/$CURATION_ID" "{
  \"nickname\": \"curator\",
  \"content\": \"수정된 큐레이팅입니다\",
  \"password\": \"$PASSWORD\",
  \"trendy\": 5,
  \"personality\": 4,
  \"practicality\": 5,
  \"costEffectiveness\": 4
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 15. 큐레이팅 수정 (잘못된 비밀번호)
############################
log "15. Update Curation - Wrong Password"
RESPONSE=$(api_call PUT "/curations/$CURATION_ID" "{
  \"nickname\": \"curator\",
  \"content\": \"수정 실패\",
  \"password\": \"$WRONG_PASSWORD\",
  \"trendy\": 1,
  \"personality\": 1,
  \"practicality\": 1,
  \"costEffectiveness\": 1
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "403"

############################
# 16. 답글 등록
############################
log "16. Create Comment (POST /curations/$CURATION_ID/comments)"
RESPONSE=$(api_call POST "/curations/$CURATION_ID/comments" "{
  \"content\": \"동의합니다\",
  \"password\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
COMMENT_ID=$(echo "$BODY" | jq -r '.id')
check_status "200"

############################
# 17. 답글 수정
############################
log "17. Update Comment (PUT /comments/$COMMENT_ID)"
RESPONSE=$(api_call PUT "/comments/$COMMENT_ID" "{
  \"content\": \"수정된 답글\",
  \"password\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 18. 답글 수정 (잘못된 비밀번호)
############################
log "18. Update Comment - Wrong Password"
RESPONSE=$(api_call PUT "/comments/$COMMENT_ID" "{
  \"content\": \"수정 실패\",
  \"password\": \"$WRONG_PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "403"

############################
# 19. 답글 삭제 (잘못된 비밀번호)
############################
log "19. Delete Comment - Wrong Password"
RESPONSE=$(api_call DELETE "/comments/$COMMENT_ID" "{\"password\": \"$WRONG_PASSWORD\"}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "403"

############################
# 20. 답글 삭제
############################
log "20. Delete Comment (DELETE /comments/$COMMENT_ID)"
RESPONSE=$(api_call DELETE "/comments/$COMMENT_ID" "{\"password\": \"$PASSWORD\"}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 21. 큐레이팅 삭제 (잘못된 비밀번호)
############################
log "21. Delete Curation - Wrong Password"
RESPONSE=$(api_call DELETE "/curations/$CURATION_ID" "{\"password\": \"$WRONG_PASSWORD\"}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "403"

############################
# 22. 큐레이팅 삭제
############################
log "22. Delete Curation (DELETE /curations/$CURATION_ID)"
RESPONSE=$(api_call DELETE "/curations/$CURATION_ID" "{\"password\": \"$PASSWORD\"}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 23. 인기 태그 목록 조회
############################
log "23. Get Popular Tags (GET /tags)"
RESPONSE=$(api_call GET "/tags")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 24. 이미지 업로드
############################
log "24. Upload Image (POST /images)"
TEST_IMAGE="/tmp/test-image-$$.png"
echo -n -e '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\x0a\x49\x44\x41\x54\x78\x9c\x63\x00\x01\x00\x00\x05\x00\x01\x0d\x0a\x2d\xb4\x00\x00\x00\x00\x49\x45\x4e\x44\xae\x42\x60\x82' > "$TEST_IMAGE"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST -F "image=@$TEST_IMAGE" "$BASE_URL/images")
rm -f "$TEST_IMAGE"
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 25. 스타일 삭제 (잘못된 비밀번호)
############################
log "25. Delete Style - Wrong Password"
RESPONSE=$(api_call DELETE "/styles/$STYLE_ID" "{\"password\": \"$WRONG_PASSWORD\"}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "403"

############################
# 26. 스타일 삭제
############################
log "26. Delete Style (DELETE /styles/$STYLE_ID)"
RESPONSE=$(api_call DELETE "/styles/$STYLE_ID" "{\"password\": \"$PASSWORD\"}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 27. 삭제된 스타일 조회 (404)
############################
log "27. Get Deleted Style - 404"
RESPONSE=$(api_call GET "/styles/$STYLE_ID")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "404"

############################
# Test Summary
############################
echo -e "\n========================================="
echo -e "\033[1;36m테스트 결과 요약\033[0m"
echo -e "========================================="
echo -e "총 테스트: $((PASSED + FAILED))"
echo -e "\033[1;32m성공: $PASSED\033[0m"
echo -e "\033[1;31m실패: $FAILED\033[0m"
echo -e "=========================================\n"

if [[ $FAILED -eq 0 ]]; then
  echo -e "\033[1;32m✔ ALL TESTS PASSED!\033[0m\n"
  exit 0
else
  echo -e "\033[1;31m✘ SOME TESTS FAILED!\033[0m\n"
  exit 1
fi
