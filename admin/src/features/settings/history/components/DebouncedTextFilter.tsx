/**
 * Company history erkin matnli filtr (`table`/`user`, 8.7, §7.13.5).
 *
 * Backendda audit qilingan jadval nomlari **yoki** muharrirlar uchun
 * katalog endpointi yo'q (umumiy audit modulida jadval nomlari uchun bor —
 * `GET /audit-log/tables` — lekin `/company/history` uchun ekvivalenti
 * **yo'q**, shuningdek muharrirlar ro'yxati uchun ham alohida endpoint yo'q,
 * D44 — `docs/tz/16-17-registry-open-questions.md`). `useUsersList`
 * (`@/api/queries/users`) `enabled` optsiyasini qo'llab-quvvatlamaydi — bu
 * fayl egaligi doirasidan tashqarida (fleet/users moduli), shuning uchun
 * `user` filtri ham ID bo'yicha erkin matn sifatida beriladi (qidiruv
 * 400ms debounce, fe-screens §1) — kelajakda foydalanuvchi nomi bo'yicha
 * qidiruvchi combobox'ga almashtirilishi mumkin.
 */
import { useEffect, useRef, useState } from 'react';

import { Input } from '@/components/ui/Input';

export interface DebouncedTextFilterProps {
  value: string;
  onChange: (value: string) => void;
  label: string;
  placeholder?: string;
  className?: string;
}

export function DebouncedTextFilter({
  value,
  onChange,
  label,
  placeholder,
  className,
}: DebouncedTextFilterProps) {
  const [inputValue, setInputValue] = useState(value);
  const timerRef = useRef<ReturnType<typeof setTimeout>>();

  useEffect(() => {
    setInputValue(value);
  }, [value]);

  useEffect(() => () => window.clearTimeout(timerRef.current), []);

  return (
    <Input
      value={inputValue}
      onChange={(event) => {
        const next = event.target.value;
        setInputValue(next);
        window.clearTimeout(timerRef.current);
        timerRef.current = setTimeout(() => onChange(next), 400);
      }}
      label={label}
      placeholder={placeholder}
      containerClassName={className}
    />
  );
}

export default DebouncedTextFilter;
