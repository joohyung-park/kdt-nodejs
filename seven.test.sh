#!/bin/bash
set -euo pipefail

############################
# Config
############################
BASE_URL="${BASE_URL:-http://localhost:3001/api}"
PASSWORD="test-password123!"
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
# 1. 그룹 생성 (POST /groups)
############################
log "1. Create Group (POST /groups)"
RESPONSE=$(api_call POST "/groups" "{
  \"name\": \"test 운동 그룹\",
  \"description\": \"자동화 test용 그룹입니다\",
  \"photoUrl\": \"https://example.com/group.jpg\",
  \"goalRep\": 100,
  \"discordWebhookUrl\": \"https://discord.com/api/webhooks/test\",
  \"discordInviteUrl\": \"https://discord.gg/test\",
  \"tags\": [\"헬스\", \"테스트\"],
  \"ownerNickname\": \"owner1\",
  \"ownerPassword\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo $BODY
GROUP_ID=$(echo "$BODY" | jq -r '.id')
check_status "201"

############################
# 2. 그룹 생성 - Invalid goalRep (400)
############################
log "2. Create Group - Invalid goalRep (400)"
RESPONSE=$(api_call POST "/groups" "{
  \"name\": \"잘못된 그룹\",
  \"description\": \"goalRep이 문자열입니다\",
  \"goalRep\": \"not-a-number\",
  \"ownerNickname\": \"owner2\",
  \"ownerPassword\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 3. 그룹 목록 조회 (GET /groups)
############################
log "3. List Groups (GET /groups)"
RESPONSE=$(api_call GET "/groups?page=1&limit=10")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 4. 그룹 목록 조회 - 추천 수 정렬 (likeCount desc)
############################
log "4. List Groups - Sort by likeCount desc"
RESPONSE=$(api_call GET "/groups?page=1&limit=10&order=desc&orderBy=likeCount")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 5. 그룹 목록 조회 - 참여자 수 정렬 (participantCount asc)
############################
log "5. List Groups - Sort by participantCount asc"
RESPONSE=$(api_call GET "/groups?page=1&limit=10&order=asc&orderBy=participantCount")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 6. 그룹 목록 조회 - 생성일 정렬 (createdAt desc)
############################
log "6. List Groups - Sort by createdAt desc"
RESPONSE=$(api_call GET "/groups?page=1&limit=10&order=desc&orderBy=createdAt")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 7. 그룹 목록 조회 - 검색
############################
log "7. List Groups - Search by name"
RESPONSE=$(api_call GET "/groups?page=1&limit=10&search=test")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 8. 그룹 목록 조회 - Invalid orderBy (400)
############################
log "8. List Groups - Invalid orderBy (400)"
RESPONSE=$(api_call GET "/groups?page=1&limit=10&orderBy=invalidField")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 9. 그룹 상세 조회 (GET /groups/{groupId})
############################
log "9. Get Group Detail (GET /groups/$GROUP_ID)"
RESPONSE=$(api_call GET "/groups/$GROUP_ID")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 10. 그룹 상세 조회 - Not Found (404)
############################
log "10. Get Group Detail - Not Found (404)"
RESPONSE=$(api_call GET "/groups/999999")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "404"

############################
# 11. 그룹 수정 (PATCH /groups/{groupId})
############################
log "11. Update Group (PATCH /groups/$GROUP_ID)"
RESPONSE=$(api_call PATCH "/groups/$GROUP_ID" "{
  \"name\": \"수정된 운동 그룹\",
  \"description\": \"수정된 설명입니다\",
  \"photoUrl\": \"https://example.com/updated.jpg\",
  \"goalRep\": 200,
  \"discordWebhookUrl\": \"https://discord.com/api/webhooks/updated\",
  \"discordInviteUrl\": \"https://discord.gg/updated\",
  \"tags\": [\"수정됨\", \"업데이트\"],
  \"ownerNickname\": \"owner1\",
  \"ownerPassword\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 12. 그룹 수정 - Wrong Password (401)
############################
log "12. Update Group - Wrong Password (401)"
RESPONSE=$(api_call PATCH "/groups/$GROUP_ID" "{
  \"name\": \"수정 실패\",
  \"description\": \"비밀번호가 틀렸습니다\",
  \"goalRep\": 300,
  \"ownerNickname\": \"owner1\",
  \"ownerPassword\": \"$WRONG_PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "401"

############################
# 13. 그룹 수정 - Invalid goalRep (400)
############################
log "13. Update Group - Invalid goalRep (400)"
RESPONSE=$(api_call PATCH "/groups/$GROUP_ID" "{
  \"name\": \"수정 실패\",
  \"goalRep\": \"not-a-number\",
  \"ownerNickname\": \"owner1\",
  \"ownerPassword\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 14. 그룹 참여 (POST /groups/{groupId}/participants)
############################
log "14. Join Group (POST /groups/$GROUP_ID/participants)"
RESPONSE=$(api_call POST "/groups/$GROUP_ID/participants" "{
  \"nickname\": \"user1\",
  \"password\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
PARTICIPANT1_ID=$(echo "$BODY" | jq -r '.participants[] | select(.nickname=="user1") | .id')
check_status "201"

############################
# 15. 그룹 참여 - 추가 참여자
############################
log "15. Join Group - Second Participant"
RESPONSE=$(api_call POST "/groups/$GROUP_ID/participants" "{
  \"nickname\": \"user2\",
  \"password\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "201"

############################
# 16. 그룹 참여 - Missing nickname (400)
############################
log "16. Join Group - Missing nickname (400)"
RESPONSE=$(api_call POST "/groups/$GROUP_ID/participants" "{
  \"password\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 17. 그룹 추천/좋아요 (POST /groups/{groupId}/likes)
############################
log "17. Like Group (POST /groups/$GROUP_ID/likes)"
RESPONSE=$(api_call POST "/groups/$GROUP_ID/likes" "")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 18. 그룹 운동 기록 생성 (POST /groups/{groupId}/records)
############################
log "18. Create Exercise Record (POST /groups/$GROUP_ID/records)"
RESPONSE=$(api_call POST "/groups/$GROUP_ID/records" "{
  \"exerciseType\": \"run\",
  \"description\": \"아침 조깅 5km\",
  \"time\": 1800,
  \"distance\": 5000,
  \"photos\": [\"https://example.com/run1.jpg\"],
  \"authorNickname\": \"user1\",
  \"authorPassword\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
RECORD_ID=$(echo "$BODY" | jq -r '.id')
check_status "201"

############################
# 19. 그룹 운동 기록 생성 - 두 번째 기록
############################
log "19. Create Exercise Record - Second Record"
RESPONSE=$(api_call POST "/groups/$GROUP_ID/records" "{
  \"exerciseType\": \"run\",
  \"description\": \"저녁 러닝 3km\",
  \"time\": 1200,
  \"distance\": 3000,
  \"photos\": [\"https://example.com/run2.jpg\"],
  \"authorNickname\": \"user2\",
  \"authorPassword\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "201"

############################
# 20. 그룹 운동 기록 생성 - Invalid groupId (400)
############################
log "20. Create Exercise Record - Invalid groupId (400)"
RESPONSE=$(api_call POST "/groups/invalid/records" "{
  \"exerciseType\": \"run\",
  \"description\": \"실패 테스트\",
  \"time\": 1000,
  \"distance\": 1000,
  \"authorNickname\": \"user1\",
  \"authorPassword\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 21. 그룹 운동 기록 목록 조회 (GET /groups/{groupId}/records)
############################
log "21. List Exercise Records (GET /groups/$GROUP_ID/records)"
RESPONSE=$(api_call GET "/groups/$GROUP_ID/records?page=1&limit=10")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 22. 그룹 운동 기록 목록 조회 - Sort by time desc
############################
log "22. List Exercise Records - Sort by time desc"
RESPONSE=$(api_call GET "/groups/$GROUP_ID/records?page=1&limit=10&order=desc&orderBy=time")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 23. 그룹 운동 기록 목록 조회 - Sort by createdAt asc
############################
log "23. List Exercise Records - Sort by createdAt asc"
RESPONSE=$(api_call GET "/groups/$GROUP_ID/records?page=1&limit=10&order=asc&orderBy=createdAt")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 24. 그룹 운동 기록 목록 조회 - Search by nickname
############################
log "24. List Exercise Records - Search by nickname"
RESPONSE=$(api_call GET "/groups/$GROUP_ID/records?page=1&limit=10&search=participant1")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 25. 그룹 운동 기록 목록 조회 - Invalid groupId (400)
############################
log "25. List Exercise Records - Invalid groupId (400)"
RESPONSE=$(api_call GET "/groups/invalid/records?page=1&limit=10")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 26. 그룹 운동 기록 상세 조회 (GET /groups/{groupId}/records/{recordId})
############################
log "26. Get Exercise Record Detail (GET /groups/$GROUP_ID/records/$RECORD_ID)"
RESPONSE=$(api_call GET "/groups/$GROUP_ID/records/$RECORD_ID")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 27. 그룹 랭킹 조회 - Weekly (GET /groups/{groupId}/rank?duration=weekly)
############################
log "27. Get Group Ranking - Weekly"
RESPONSE=$(api_call GET "/groups/$GROUP_ID/rank?duration=weekly")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 28. 그룹 랭킹 조회 - Monthly (GET /groups/{groupId}/rank?duration=monthly)
############################
log "28. Get Group Ranking - Monthly"
RESPONSE=$(api_call GET "/groups/$GROUP_ID/rank?duration=monthly")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 29. 그룹 랭킹 조회 - Invalid groupId (400)
############################
log "29. Get Group Ranking - Invalid groupId (400)"
RESPONSE=$(api_call GET "/groups/invalid/rank?duration=weekly")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 30. 이미지 파일 업로드 (POST /images)
############################
log "30. Upload Image (POST /images)"
TEST_IMAGE="/tmp/test-image-$$.png"
echo -n -e '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\x0a\x49\x44\x41\x54\x78\x9c\x63\x00\x01\x00\x00\x05\x00\x01\x0d\x0a\x2d\xb4\x00\x00\x00\x00\x49\x45\x4e\x44\xae\x42\x60\x82' > "$TEST_IMAGE"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST -F "files=@$TEST_IMAGE" "$BASE_URL/images")
rm -f "$TEST_IMAGE"
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 31. 이미지 파일 업로드 - Invalid file type (400)
############################
log "31. Upload Image - Invalid file type (400)"
TEST_TEXT="/tmp/test-text-$$.txt"
echo "This is not an image" > "$TEST_TEXT"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST -F "files=@$TEST_TEXT" "$BASE_URL/images")
rm -f "$TEST_TEXT"
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 32. 그룹 추천/좋아요 취소 (DELETE /groups/{groupId}/likes)
############################
log "32. Unlike Group (DELETE /groups/$GROUP_ID/likes)"
RESPONSE=$(api_call DELETE "/groups/$GROUP_ID/likes" "")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 33. 그룹 참여 취소 (DELETE /groups/{groupId}/participants)
############################
log "33. Leave Group (DELETE /groups/$GROUP_ID/participants)"
RESPONSE=$(api_call DELETE "/groups/$GROUP_ID/participants" "{
  \"nickname\": \"user2\",
  \"password\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "204"

############################
# 34. 그룹 참여 취소 - Missing nickname (400)
############################
log "34. Leave Group - Missing nickname (400)"
RESPONSE=$(api_call DELETE "/groups/$GROUP_ID/participants" "{
  \"password\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "400"

############################
# 35. 그룹 참여 취소 - Wrong Password (401)
############################
log "35. Leave Group - Wrong Password (401)"
RESPONSE=$(api_call DELETE "/groups/$GROUP_ID/participants" "{
  \"nickname\": \"user1\",
  \"password\": \"$WRONG_PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "401"

############################
# 36. 그룹 삭제 - Wrong Password (401)
############################
log "36. Delete Group - Wrong Password (401)"
RESPONSE=$(api_call DELETE "/groups/$GROUP_ID" "{
  \"ownerPassword\": \"$WRONG_PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "401"

############################
# 37. 그룹 삭제 (DELETE /groups/{groupId})
############################
log "37. Delete Group (DELETE /groups/$GROUP_ID)"
RESPONSE=$(api_call DELETE "/groups/$GROUP_ID" "{
  \"ownerPassword\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "200"

############################
# 38. 삭제된 그룹 조회 - Not Found (404)
############################
log "38. Get Deleted Group - Not Found (404)"
RESPONSE=$(api_call GET "/groups/$GROUP_ID")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "404"

############################
# 39. 삭제된 그룹에 참여 시도 - Not Found (404)
############################
log "39. Join Deleted Group - Not Found (404)"
RESPONSE=$(api_call POST "/groups/$GROUP_ID/participants" "{
  \"nickname\": \"user3\",
  \"password\": \"$PASSWORD\"
}")
HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
check_status "404"

############################
# 40. 삭제된 그룹의 운동 기록 조회 - Not Found (404)
############################
log "40. List Records of Deleted Group - Not Found (404)"
RESPONSE=$(api_call GET "/groups/$GROUP_ID/records?page=1&limit=10")
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
