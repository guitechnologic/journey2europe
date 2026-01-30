export interface OptionalField {
  enabled: boolean;
  value: string;
}

export interface PersonalData {
  firstName: string;
  lastName: string;

  headline: string;
  showHeadline: boolean;

  email: string;
  phone: string;

  address: string;
  postalCode: string;
  city: string;
  state: string;
  country: string;

  photo?: string;

  birthDate: OptionalField;
  naturality: OptionalField;
  gender: OptionalField;
  nationality: OptionalField;
  maritalStatus: OptionalField;
  website: OptionalField;
  linkedin: OptionalField;
  github: OptionalField;
  custom: OptionalField;
}

export interface EuropassCV {
  personal: PersonalData;
}
