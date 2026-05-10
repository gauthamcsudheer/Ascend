import { PrismaClient, Persona } from '@prisma/client';
import argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  const adminEmail = process.env.SEED_ADMIN_EMAIL;
  const adminPassword = process.env.SEED_ADMIN_PASSWORD;
  if (!adminEmail || !adminPassword) {
    throw new Error('SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD must be set in .env');
  }

  console.log('Seeding admin account...');
  const admin = await prisma.user.upsert({
    where: { email: adminEmail },
    update: {},
    create: {
      email: adminEmail,
      name: 'Admin',
      persona: Persona.FACULTY,
      department: 'Administration',
      passwordHash: await argon2.hash(adminPassword),
      emailVerifiedAt: new Date(),
    },
  });

  await prisma.adminRole.upsert({
    where: { userId: admin.id },
    update: {},
    create: { userId: admin.id, grantedById: admin.id },
  });

  console.log(`Admin seeded: ${admin.email}`);

  if (process.env.NODE_ENV === 'development') {
    console.log('Seeding development test accounts...');

    const testStudent = await prisma.user.upsert({
      where: { email: 'student@ascend.local' },
      update: {},
      create: {
        email: 'student@ascend.local',
        name: 'Test Student',
        persona: Persona.STUDENT,
        branch: 'CSE',
        semester: 3,
        batchYear: 2027,
        passwordHash: await argon2.hash('password123'),
        emailVerifiedAt: new Date(),
      },
    });

    const testFaculty = await prisma.user.upsert({
      where: { email: 'faculty@ascend.local' },
      update: {},
      create: {
        email: 'faculty@ascend.local',
        name: 'Test Faculty',
        persona: Persona.FACULTY,
        department: 'Computer Science',
        passwordHash: await argon2.hash('password123'),
        emailVerifiedAt: new Date(),
      },
    });

    const testAlumnus = await prisma.user.upsert({
      where: { email: 'alumnus@ascend.local' },
      update: {},
      create: {
        email: 'alumnus@ascend.local',
        name: 'Test Alumnus',
        persona: Persona.ALUMNUS,
        branch: 'CSE',
        batchYear: 2022,
        currentRole: 'Software Engineer',
        currentCompany: 'Acme Corp',
        passwordHash: await argon2.hash('password123'),
        emailVerifiedAt: new Date(),
      },
    });

    console.log(`Dev users seeded: ${testStudent.email}, ${testFaculty.email}, ${testAlumnus.email}`);
  }

  console.log('Seeding active academic calendar...');
  await prisma.academicCalendar.upsert({
    where: { id: 'seed-cal-2026' },
    update: {},
    create: {
      id: 'seed-cal-2026',
      semesterLabel: 'Even Semester 2025-26',
      startsAt: new Date('2026-01-06'),
      endsAt: new Date('2026-05-31'),
      active: true,
    },
  });

  console.log('Done.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
