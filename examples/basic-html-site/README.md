# Basic HTML Site 예제

수업용 OX 퀴즈 예제입니다. `index.html` 하나에 HTML, CSS, JavaScript가 모두 들어 있어 빌드 도구 없이 바로 실행할 수 있습니다.

## 로컬에서 여는 방법

`index.html` 파일을 더블클릭하면 브라우저에서 바로 열립니다.

## `npx serve .`로 확인하는 방법

```bash
cd examples/basic-html-site
npx serve .
```

화면에 표시되는 주소를 브라우저에서 엽니다. 보통 `http://localhost:3000` 또는 비슷한 주소가 나옵니다.

## GitHub Pages로 배포하는 방법

이 폴더의 `index.html`을 새 저장소 루트에 복사한 뒤 실행합니다.

```bash
git init
git add .
git commit -m "첫 수업용 웹사이트 만들기"
gh repo create my-class-site --public --source=. --remote=origin --push
```

GitHub 웹에서 `Settings` → `Pages` → `Build and deployment`로 이동한 뒤 다음처럼 설정합니다.

- Source: `Deploy from a branch`
- Branch: `main`
- Folder: `/root`

연수용 저장소는 public으로 만드세요. GitHub Pages는 인터넷에 공개됩니다.

## AI에게 수정 요청하는 예시 프롬프트

```text
이 OX 퀴즈를 중학교 과학 수업용으로 바꿔줘.
문항은 5개로 늘리고, 각 문항에 짧은 해설을 넣어줘.
디자인은 모바일에서 보기 편하게 유지해줘.
외부 API나 빌드 도구는 사용하지 말고 index.html 하나만 수정해줘.
```

```text
정답 확인 후 틀린 문제만 다시 풀 수 있게 바꿔줘.
학생 개인정보를 저장하거나 전송하지 않게 해줘.
```
