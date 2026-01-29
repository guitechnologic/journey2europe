import { EuropassCV } from "../europass-types";

export function generateEuropassHTML(data: EuropassCV): string {
  return `
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8" />
  < title>Currículo Europass</title>
  <style>
    body {
      font-family: Arial, Helvetica, sans-serif;
      margin: 40px;
      color: #000;
    }
    h1 {
      font-size: 26px;
      border-bottom: 2px solid #000;
      padding-bottom: 5px;
    }
    h2 {
      font-size: 18px;
      margin-top: 30px;
    }
    .section {
      margin-bottom: 20px;
    }
    .item {
      margin-bottom: 10px;
    }
    .label {
      font-weight: bold;
    }
  </style>
</head>
<body>

  <h1>${data.fullName}</h1>
  <p>${data.location} | ${data.email}</p>

  <div class="section">
    <h2>Experiência Profissional</h2>
    ${data.experiences
      .map(
        (exp) => `
        <div class="item">
          <div class="label">${exp.role} – ${exp.company}</div>
          <div>${exp.startDate} - ${exp.endDate}</div>
          <div>${exp.description}</div>
        </div>
      `
      )
      .join("")}
  </div>

  <div class="section">
    <h2>Formação</h2>
    ${data.education
      .map(
        (edu) => `
        <div class="item">
          <div class="label">${edu.course}</div>
          <div>${edu.institution} (${edu.year})</div>
        </div>
      `
      )
      .join("")}
  </div>

  <div class="section">
    <h2>Competências</h2>
    <p>${data.skills}</p>
  </div>

</body>
</html>
`;
}
