import { EuropassCV } from "@/lib/europass-types";

export default function EuropassPreview({ cv }: { cv: EuropassCV }) {
  const p = cv.personal;

  return (
    <div className="bg-white min-h-[900px] grid grid-cols-[260px_1fr]">
      {/* COLUNA ESQUERDA */}
      <aside className="bg-[#2f4e73] text-white p-6 space-y-6">
        <div className="h-32 bg-white/20 flex items-center justify-center">
          Foto
        </div>

        <div>
          <h1 className="font-bold text-lg">
            {p.firstName} {p.lastName}
          </h1>
          {p.showHeadline && (
            <p className="text-sm mt-1">{p.headline}</p>
          )}
        </div>

        <div className="space-y-2 text-sm">
          {p.email && <p>{p.email}</p>}
          {p.phone && <p>{p.phone}</p>}
          {p.address && <p>{p.address}</p>}
          {p.postalCode && p.city && (
            <p>
              {p.postalCode} {p.city}
            </p>
          )}

          {Object.entries(p).map(([_, field]: any) =>
            field?.enabled && field.value ? (
              <p key={_}>{field.value}</p>
            ) : null
          )}
        </div>
      </aside>

      {/* COLUNA DIREITA */}
      <section className="p-8 space-y-6">
        <div>
          <h2 className="text-xl font-semibold border-b pb-1">
            Resumo profissional
          </h2>
          <p className="text-sm text-gray-600 mt-2">
            Conteúdo do resumo virá aqui
          </p>
        </div>

        <div>
          <h2 className="text-xl font-semibold border-b pb-1">
            Formação
          </h2>
        </div>

        <div>
          <h2 className="text-xl font-semibold border-b pb-1">
            Experiência
          </h2>
        </div>
      </section>
    </div>
  );
}
