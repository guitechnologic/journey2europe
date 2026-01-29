export interface Experience {
  role: string;
  company: string;
  startDate: string;
  endDate: string;
  description: string;
}

export interface Education {
  course: string;
  institution: string;
  year: string;
}

export interface EuropassCV {
  fullName: string;
  email: string;
  location: string;
  experiences: Experience[];
  education: Education[];
  skills: string;
}
