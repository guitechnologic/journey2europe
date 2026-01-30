"use client";

import { EuropassCV } from "@/lib/europass-types";

interface Props {
  cv: EuropassCV;
  setCv: (cv: EuropassCV) => void;
}

export default function PersonalDataForm({ cv, setCv }: Props) {
  const p = cv.personal;

  function update(field: string, value: any) {
    setCv({
      ...cv,
      personal: {
        ...p,
        [field]: value,
      },
    });
  }

  function updateOptional(field: keyof typeof p, value: string) {
    update(field, { ...p[field], value });
  }

  function enableOptional(field: keyof typeof p) {
    update(field, { ...p[field], enabled: true });
  }

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-semibold">
        {p.firstName} {p.lastName}
      </h2>

      {/* FOTO + NOME */}
      <div className="grid grid-cols-[120px_1fr] gap-4">
        <div className="border rounded flex items-center justify-center h-[120px] text-sm text-gray-500">
          Foto
        </div>

        <div className="space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <input
              placeholder="Nome"
              value={p.firstName}
              onChange={(e) => update("firstName", e.target.value)}
              className="input"
            />
            <input
              placeholder="Sobrenome"
              value={p.lastName}
              onChange={(e) => update("lastName", e.target.value)}
              className="input"
            />
          </div>

          <div className="flex items-center gap-3">
            <input
              placeholder="Cargos desejados"
              value={p.headline}
              onChange={(e) => update("headline", e.target.value)}
              className="input flex-1"
            />
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={p.showHeadline}
                onChange={(e) =>
                  update("showHeadline", e.target.checked)
                }
              />
              Usar como título
            </label>
          </div>
        </div>
      </div>

      {/* EMAIL / TELEFONE */}
      <div className="grid grid-cols-2 gap-4">
        <input
          placeholder="E-mail"
          value={p.email}
          onChange={(e) => update("email", e.target.value)}
          className="input"
        />
        <input
          placeholder="+55 41 9 9592 3520"
          value={p.phone}
          onChange={(e) => update("phone", e.target.value)}
          className="input"
        />
      </div>

      {/* ENDEREÇO */}
      <input
        placeholder="Endereço completo"
        value={p.address}
        onChange={(e) => update("address", e.target.value)}
        className="input"
      />

      {/* CEP / CIDADE */}
      <div className="grid grid-cols-2 gap-4">
        <input
          placeholder="CEP / Código postal"
          value={p.postalCode}
          onChange={(e) => update("postalCode", e.target.value)}
          className="input"
        />
        <input
          placeholder="Cidade"
          value={p.city}
          onChange={(e) => update("city", e.target.value)}
          className="input"
        />
      </div>

      {/* CAMPOS OPCIONAIS ATIVOS */}
      <div className="space-y-3">
        {Object.entries(p).map(([key, field]: any) =>
          field?.enabled ? (
            <input
              key={key}
              placeholder={key}
              value={field.value}
              onChange={(e) =>
                updateOptional(key as any, e.target.value)
              }
              className="input"
            />
          ) : null
        )}
      </div>

      {/* BOTÕES ADD */}
      <div className="flex flex-wrap gap-2 pt-2">
        {Object.entries(p).map(([key, field]: any) =>
          field?.enabled === false ? (
            <button
              key={key}
              onClick={() => enableOptional(key as any)}
              className="px-3 py-1 rounded-full border text-sm hover:bg-gray-100"
            >
              + {key}
            </button>
          ) : null
        )}
      </div>
    </div>
  );
}
