export interface Profile {
  id: string;
  updated_at: string;
  username: string;
  full_name?: string;
  avatar_url?: string;
  website?: string;
}

export interface NewsProvider {
  id: number;
  created_at: string;
  created_by: string;
  is_activated: boolean;
  is_google_news: boolean;
}

export interface NewsSettings {
  id: number;
  created_at: string;
  created_by: string;
  interests: string;
  wants_interests: boolean;
  countries: string;
  wants_countries: boolean;
  cities: string;
  wants_cities: boolean;
  user_prompt: string;
  providers: string[];
  locale: string;
}

export interface News {
  title: string;
  description: string;
  content: string;
  publishedAt: Date;
  url: string;
  source: {
    name: string;
    url: string;
  };
}
/**
 * Describes the URL or URI of a provider.
 */
export type Provider = string;
