# Midterm: quick oral review (EN / UZ)

| Question | English answer | O‘zbekcha javob |
|---|---|---|
| Design vs architecture? | Design specifies behavior; architecture allocates responsibilities and communication. | Design xatti-harakatni, arxitektura qismlar vazifasi va aloqasini belgilaydi. |
| What is a process? | A running program with its own PID and resources. | PID va resurslarga ega ishlayotgan dastur. |
| Thread? | An execution path inside a process. | Process ichidagi bajarilish oqimi. |
| Kernel? | Privileged OS core that manages hardware and resources. | Resurslarni boshqaruvchi OT yadrosi. |
| UML? | Diagrams to communicate structure and behavior. | Tuzilish va xatti-harakat diagrammalari. |
| Half-open date range? | Includes check-in, excludes check-out. | Kirish kuni kiradi, chiqish kuni kirmaydi. |
| Refactoring? | Improve internal design without changing observable behavior. | Tashqi xatti-harakatni o‘zgartirmay kodni yaxshilash. |
| SOLID? | Single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion. | Bitta mas’uliyat, kengaytirishga ochiq, o‘rinbosarlik, interfeys ajratish, abstraksiyaga bog‘lanish. |
| Dependency injection? | Pass dependencies into the service instead of constructing them inside it. | Bog‘liqlikni service ichida yaratmasdan tashqaridan berish. |
| Bounded context? | A business boundary with its own vocabulary and rules. | O‘z atamalari va qoidalari bor biznes sohasi. |
| Modular monolith? | One deployment with internal module boundaries. | Bitta deploy, ichida aniq modul chegaralari. |
| ADR? | Record a decision, alternatives, reasons and consequences. | Arxitektura qarori, variantlar va oqibatlari yozuvi. |
| REST status codes? | 200 success, 201 created, 204 no content, 400 invalid, 404 absent, 409 conflict. | 200 muvaffaqiyat, 201 yaratildi, 204 tanasiz, 400 noto‘g‘ri, 404 topilmadi, 409 ziddiyat. |
| Why PostgreSQL? | Durable shared data and constraints. | Saqlanadigan umumiy ma’lumot va cheklovlar. |
| Cache-aside? | Read cache; on miss query DB and store copy. | Avval kesh, topilmasa baza va keshga yozish. |
| TTL? | Time to live; cached value expires. | Kesh qiymatining yashash muddati. |
| Race condition? | Result depends on overlapping execution order. | Natija parallel bajarilish tartibiga bog‘liq. |
| Why exclusion constraint? | Database rejects overlapping confirmed stays even across instances. | Bir nechta serverda ham ustma-ust bronni baza rad etadi. |
| Backpressure? | Bound outstanding work; reject or delay when saturated. | Navbat to‘lganda yukni cheklash. |
| Graceful shutdown? | Stop and drain outstanding work before exit. | Chiqishdan oldin navbatdagi ishlarni tugatish. |
| Idempotency? | Same key and payload replay same committed result without repeating the action. | Bir xil kalit va so‘rov qayta kelganda amal takrorlanmaydi. |
| Correlation ID? | Trace related requests across logs. | Bog‘liq so‘rovlarni loglarda kuzatish ID si. |

Do not claim measured times or successful tests without running them. Explain P03/P08 deliberate race, P09 storage invariant, and P11 simulator limitations.
