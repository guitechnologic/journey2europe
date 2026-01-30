"use client";

import { useState } from "react";
import { EuropassCV } from "@/lib/europass-types";
import PersonalDataForm from "./PersonalDataForm";
import EuropassPreview from "./EuropassPreview";

const initialCV: EuropassCV = {
  personal: {
    firstName: "",
    lastName: "",
    headline: "",
    showHeadline: true,
    email: "",
    phone: "",
    address: "",
    postalCode: "",
    city: "",
    state: "",
    country: "",

    birthDate: { enabled: false, value: "" },
    naturality: { enabled: false, value: "" },
    gender: { enabled: false, value: "" },
    nationality: { enabled: false, value: "" },
    maritalStatus: { enabled: false, value: "" },
    website: { enabled: false, value: "" },
    linkedin: { enabled: false, value: "" },
    github: { enabled: false, value: "" },
    custom: { enabled: false, value: "" },
  },
};

export default function EuropassPage() {
  const [cv, setCv] = useState<EuropassCV>(initialCV);

  return (
    <main className="min-h-screen grid grid-cols-1 md:grid-cols-2 gap-6 p-6">
      <div className="bg-white rounded p-4 shadow">
        <PersonalDataForm cv={cv} setCv={setCv} />
      </div>

      <div className="bg-gray-50 rounded p-4 shadow">
        <EuropassPreview cv={cv} />
      </div>
    </main>
  );
}
