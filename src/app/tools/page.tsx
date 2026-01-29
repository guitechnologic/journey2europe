"use client";

import { useState } from "react";

export default function EuropassPage() {
  const [loading, setLoading] = useState(false);

  const [form, setForm] = useState({
    fullName: "",
    email: "",
    location: "",
    skills: "",
  });

  const handleChange = (e: any) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const generatePDF = async () => {
    setLoading(true);

    const response = await fetch("/api/generate-cv", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        ...form,
        experiences: [
          {
            role: "DevOps Engineer",
            company: "Empresa Exemplo",
            startDate: "2023",
            endDate: "2025",
            description: "Automação, CI/CD e cloud.",
          },
        ],
        education: [
          {
            course: "Análise e Desenvolvimento de Sistemas",
            institution: "Universidade Exemplo",
            year: "2022",
          },
        ],
      }),
    });

    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);

    const a = document.createElement("a");
    a.href = url;
    a.download = "curriculo-europass.pdf";
    a.click();

    setLoading(false);
  };

  return (
    <main className="min-h-screen p-8">
      <h1 className="text-3xl font-bold mb-6">
        Gerador de Currículo Europass
      </h1>

      <div className="space-y-4 max-w-xl">
        <input
          name="fullName"
          placeholder="Nome completo"
          className="w-full border p-2 rounded"
          onChange={handleChange}
        />

        <input
          name="email"
          placeholder="Email"
          className="w-full border p-2 rounded"
          onChange={handleChange}
        />

        <input
          name="location"
          placeholder="Localização"
          className="w-full border p-2 rounded"
          onChange={handleChange}
        />

        <textarea
          name="skills"
          placeholder="Competências"
          className="w-full border p-2 rounded"
          onChange={handleChange}
        />

        <button
          onClick={generatePDF}
          disabled={loading}
          className="bg-black text-white px-4 py-2 rounded"
        >
          {loading ? "Gerando..." : "Gerar PDF"}
        </button>
      </div>
    </main>
  );
}
