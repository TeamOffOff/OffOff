<img width="350" src="https://user-images.githubusercontent.com/22260098/142892162-62d46007-8ba6-439b-b67b-b3cfc82dc9a7.png">

# 오프오프

👩‍⚕️간호사, 간호전공학생들을 위한 커뮤니티 어플리케이션👨‍⚕️

# 주요 기능

## iOS 🍎

|**회원가입**|**로그인**|
|------|-----|
|![Simulator Screen Recording - iPhone 12 Pro Max - 2021-11-21 at 22 43 27](https://user-images.githubusercontent.com/22260098/142764290-6c2c9bb0-abdf-46a0-91d5-ae7926d02ab2.gif)|![Simulator Screen Recording - iPhone 12 Pro Max - 2021-11-21 at 23 38 56](https://user-images.githubusercontent.com/22260098/142766352-f9131b21-7173-411b-a096-3554755c39a3.gif)|

- Moya를 통한 네트워킹으로 아이디, 닉네임, 이메일 중복 검사
- Bearer token을 keychain에 저장하여 자동 로그인, 토큰 인증 구현

<hr>

|**게시판, 글 조회**|**글 작성**|**좋아요 / 댓글, 대댓글 작성**|
|------|-----|-----|
|![Simulator Screen Recording - iPhone 12 Pro Max - 2021-11-22 at 00 01 20](https://user-images.githubusercontent.com/22260098/142767296-47e7dec6-abde-4b9e-8be6-8172fab14d6d.gif)|![Simulator Screen Recording - iPhone 12 Pro Max - 2021-11-22 at 00 06 31](https://user-images.githubusercontent.com/22260098/142767474-de1645a5-54ef-4f12-8e1c-8d974bf7b4d5.gif)|![Simulator Screen Recording - iPhone 12 Pro Max - 2021-11-22 at 18 13 22](https://user-images.githubusercontent.com/22260098/142834439-b578cd49-8ac8-4e0c-b50d-3790d5cd8043.gif)|

- UIRefreshControl로 상단 리프레시, UITableViewDelegate로 하단 스크롤 리프레시 구현
- 게시글 리스트, 게시글 조회 / 게시글 작성 시 로딩 Indicator 표시

<hr>

**교대근무 일정 관리 (구현 중)**

![Simulator Screen Recording - iPhone 12 Pro Max - 2021-11-23 at 00 59 36](https://user-images.githubusercontent.com/22260098/142894219-01eb71e3-3fcb-4aef-a6cd-77446d55100e.gif)

- FSCalendar로 달력 구현, 커스텀
- Realm으로 데이터 저장, 오프라인에서도 일정 확인할 수 있도록 구현

## 사용한 기술

- **Swift**
- **RxSwift** : UI 이벤트, 데이터 갱신, 비동기, Thread 처리
- **Moya** : 네트워킹
- **SnapKit** / **Then** : UI 구현
- **Realm** : 근무교대 일정 저장


