export default function EuropassPage() {
  return (
    <main className="min-h-screen p-8">
      <h1 className="text-3xl font-bold mb-4">
        Gerador de Currículo Europass
      </h1>

      <p className="mb-6">
        Preencha seus dados e gere seu currículo no padrão Europass gratuitamente.
      </p>

      <form className="space-y-4 max-w-xl">
        <input
          type="text"
          placeholder="Nome completo"
          className="w-full border p-2 rounded"
        />

        <input
          type="email"
          placeholder="Email"
          className="w-full border p-2 rounded"
        />

        <input
          type="text"
          placeholder="Localização (cidade, país)"
          className="w-full border p-2 rounded"
        />

        <button
          type="button"
          className="bg-black text-white px-4 py-2 rounded"
        >
          Gerar PDF (em breve)
        </button>
      </form>
    </main>
  );
}
